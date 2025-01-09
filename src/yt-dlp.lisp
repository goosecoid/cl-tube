(in-package :tube)

(defun vid-url->formats-list-output (url)
  "capture the --list-formats output so we can obtain the audio/video codes"
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
