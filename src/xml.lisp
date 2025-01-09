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
               (xmls:extract-path '("feed" "author" "name"))
               (xmls:node->nodelist)
               (last)
               (first)))
           (get-url (pxml)
             (->> pxml
               (xmls:extract-path '("feed" "author" "uri"))
               (xmls:node->nodelist)
               (last)
               (first)))
           (get-vid (pxml)
             (let* ((flat-video-entries
                      (-<>
                        pxml
                        (xmls:extract-path '("feed") <>)
                        (xmls:node->nodelist)
                        (subseq <> 9)
                        (mapcar
                         (lambda (e)
                           (-<> e
                             (mapcar (lambda (e) (cdr e)) <>)
                             (remove-if #'stringp <>)
                             (mapcar (lambda (e) (cdr e)) <>)
                             (alexandria:flatten <>)))
                         <>))))
                    (mapcar (lambda (v)
                              (let ((title (nth 3 v))
                                    (url (nth 24 v))
                                    (publishedAt (nth 11 v))
                                    (thumbnail (nth 32 v)))
                                (list title url publishedAt thumbnail)))
                            flat-video-entries))))

      (unless (eql resp 'NOT-FOUND)
        (let ((parsed-xml (xmls:parse resp)))
          (list (get-name parsed-xml) (get-url parsed-xml) (get-vid parsed-xml)))))))

(defun opml-file->all-channels-info (file-path)
  (mapcar
   (lambda (u)
     (channel-url->channel-info u))
   (opml-file->channel-urls file-path)))
