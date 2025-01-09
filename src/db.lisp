(in-package :tube)

(defun bootstrap-db ()
  (mito:connect-toplevel
   :sqlite3
   :database-name "tube.db")

  (mito:deftable channel ()
    ((name :col-type (:varchar 64))
     (url :col-type :text)))

  (mito:deftable video ()
    ((title :col-type :text)
     (url :col-type :text)
     (published_at :col-type :timestamp)
     (thumbnail :col-type :text)
     (channel :col-type channel)))

  (mapc
   (lambda (table)
     (progn
       (mito:ensure-table-exists table)
       (mito:migrate-table table)))
   '(channel video))

  (populate-db-with-channels-info)
  ;; (unless (mito:find-dao 'channel)
  ;;  (populate-db-with-channels-info))
  )

(defun populate-db-with-channels-info ()
    ;; TODO: command-line arg
    (let ((channels-info
            (opml-file->all-channels-info "~/Downloads/subscriptions.opml")))
      (mapc (lambda (c)
              (let* ((channel (create-channel (car c) (cadr c)))
                    (videos (mapcar
                             (lambda (v)
                               (create-video
                                (car v)
                                (cadr v)
                                (caddr v)
                                (cadddr v)
                                channel))
                             (caddr c))))
                (mito:insert-dao channel)
                (mapc #'mito:insert-dao videos)))
            channels-info)))

(defun create-channel (name url)
  (make-instance 'channel :name name :url url))

(defun create-video (title url published_at thumbnail channel)
  (make-instance
   'video
   :title title
   :url url
   :published_at (local-time:parse-timestring published_at)
   :thumbnail thumbnail
   :channel channel))

(defun get-channels ()
  (mito:retrieve-dao 'channel))

(defun get-videos ()
  (mito:retrieve-dao 'video))

(defun get-videos-for-channel (channel)
  (mito:retrieve-dao 'video :channel channel))
