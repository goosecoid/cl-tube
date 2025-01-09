(in-package :tube)

(defun opml-file->channel-urls (opml-file)
  (->>
    opml-file
    (pathname)
    (uiop:read-file-string)
    (xmls:parse)
    (xmls:extract-path '("opml" "body" "outline"))
    (xmls:node->nodelist)
    (cddr)
    (mapcar (lambda (l) (->> l (cdaadr) (first))))))

(defun channel-url->channel-info (url)
  ;; (let ((parsed-xml (->> (dex:get url) (xmls:parse))))
  (let ((resp (handler-case (dex:get url) (dex:http-request-not-found () 'NOT-FOUND))))
    (flet ((get-name (pxml)
             (->> pxml
               (xmls:extract-path '("feed" "title"))
               (xmls:node->nodelist)
               (last)
               (first)))
           (get-vid-urls (pxml)
             (-<> pxml
               (xmls:extract-path '("feed") <>)
               (xmls:node->nodelist <>)
               (subseq <> 9)
               (mapcar (lambda (entry) (-<> entry
                                         (subseq <> 5 7)
                                         (mapcar (lambda (item) (cdr item)) <>)))
                       <>)
               (loop :for (title-node url-node) :in <>
                     :collect (list (cadr title-node) (cadaar url-node))))))

      (unless (eql resp 'NOT-FOUND)
        (let ((parsed-xml (xmls:parse resp)))
          (list (get-name parsed-xml) (get-vid-urls parsed-xml)))))))

(defun opml-file->all-channels-info (file-path)
  (mapcar
   (lambda (u)
     (channel-url->channel-info u))
   (opml-file->channel-urls file-path)))
