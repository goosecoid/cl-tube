(in-package :tube)

(defparameter *channels* "~/Downloads/subscriptions.opml")
(defparameter *channel-urls* (opml-file->channel-urls *channels*))
(defparameter *recent-vids-list-first-channel* (channel-url->channel-info (first *channel-urls*)))

;; Outputs the available formats to "output.txt"
;; (vid-url->formats-list-output (first (cdaadr *recent-vids-list-first-channel*)))

;; (launch-video
;;  (first (cdaadr *recent-vids-list-first-channel*))
;;  (audio-video-quality->dl-code "output.txt" "1080x1920" "medium"))
