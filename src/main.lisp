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
  (let ((parsed-xml (->> (dex:get url) (xmls:parse))))
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

      (list (get-name parsed-xml) (get-vid-urls parsed-xml)))))

(defun vid-url->formats-list (url)
  (uiop:run-program `("yt-dlp" ,url  "--list-formats") :output "output.txt"))

;; TODO Should probably sort based on file size or other criteria
(defun resolution->video-code (file resolution)
  "Returns a video code for a certain resolution, f.e: '720x1280'
   and a file containing the --list-formats standard output"
  (->> file
     (uiop:read-file-string)
     (str:split #\n)
     (remove-if-not (lambda (s) (str:containsp resolution s)))
     (first)
     (str:split #\SPACE)
     (remove-if (lambda (s) (str:emptyp s)))
     (nth 2)
     (str:split #\NEWLINE)
     (cadr)))

(defun quality->audio-code (file quality)
  "Returns an audio code for a certain quality (ultralow|low|medium)'
   and a file containing the --list-formats standard output"
  (->> file
    (uiop:read-file-string)
    (str:split #\n)
    (remove-if-not (lambda (s) (and (str:containsp "audio" s)
                                    (if (string-equal quality "low")
                                        (and (str:containsp quality s)
                                             (not (str:containsp "ultra" s)))
                                        (str:containsp quality s)))))
    (cdr)
    (first)
    (str:split #\SPACE)
    (remove-if (lambda (s) (str:emptyp s)))
    (nth 3)
    (str:split #\NEWLINE)
    (cadr)))

(defun audio-video-quality->dl-code (file resolution quality)
  (format
   nil
   "~A+~A"
   (resolution->video-code file resolution)
   (quality->audio-code file quality)))

(defun launch-video (url code)
  (let ((command (format nil "yt-dlp -o - ~A -f ~A | mpv -" url code)))
    (uiop:run-program command :error-output "mpv-output.txt")))

(defparameter *channels* "~/Downloads/subscriptions.opml")
(defparameter *channel-urls* (opml-file->channel-urls *channels*))
(defparameter *recent-vids-list-first-channel* (channel-url->channel-info (first *channel-urls*)))

;; Outputs the available formats to "output.txt"
;; (vid-url->formats-list (first (cdaadr *recent-vids-list-first-channel*)))

;; (launch-video
;;  (first (cdaadr *recent-vids-list-first-channel*))
;;  (audio-video-quality->dl-code "output.txt" "1080x1920" "medium"))
