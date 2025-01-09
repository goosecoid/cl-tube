(in-package :tube)

(defun bootstrap-db ()
  (mito:connect-toplevel
   :sqlite3
   :database-name "tube.db")

  (mito:deftable channel ()
    ((name :col-type (:varchar 64))))

  (mito:deftable video ()
    ((title :col-type :text)
     (url :col-type :text)
     (channel :col-type channel)))

  (mapc
   (lambda (table)
     (progn
       (mito:ensure-table-exists table)
       (mito:migrate-table table)))
   '(channel video))

  (populate-db-with-channels-info))

(defun populate-db-with-channels-info ()
    ;; TODO: command-line arg
    (let ((channels-info (opml-file->all-channels-info "~/Downloads/subscriptions.opml")))
      (mapc (lambda (c)
              (let* ((channel (create-channel (car c)))
                     (videos (mapcar
                              (lambda (v) (create-video (car v) (cadr v) channel))
                              (cadr c))))
                (mito:insert-dao channel)
                (mapc #'mito:insert-dao videos)))
            channels-info)))

(defun create-channel (name)
  (make-instance 'channel :name name))

(defun create-video (title url channel)
  (make-instance
   'video
   :title title
   :url url
   :channel channel))
