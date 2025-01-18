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

  (unless (mito:find-dao 'channel)
   (populate-db-with-channels-info)))

(defun populate-db-with-channels-info ()
    ;; TODO: command-line arg
    (let ((channels-info
            (opml-file->all-channels-info "~/Downloads/subscriptions.opml")))
      (mapc (lambda (c)
              (let* ((channel (create-channel (car c) (cadr c)))
                    (videos (mapcar
                             (lambda (v) (create-video v channel))
                             (caddr c))))
                (mito:insert-dao channel)
                (mapc #'mito:insert-dao videos)))
            channels-info)))

(defun create-channel (name url)
  (make-instance 'channel :name name :url url))

(defun create-video (video-data channel)
  (make-instance
   'video
   :title (car video-data)
   :url (cadr video-data)
   :published_at (local-time:parse-timestring (caddr video-data))
   :thumbnail (cadddr video-data)
   :channel channel))

(defun get-channels ()
  (mito:retrieve-dao 'channel))

(defun get-videos ()
  (mito:retrieve-dao 'video))

(defun get-videos-for-channel (channel)
  (mito:retrieve-dao 'video :channel channel))

(defun get-latest-videos ()
  (->
    (mito:retrieve-dao 'video)
    (sort #'local-time:timestamp>
          :key (lambda (v) (slot-value v 'publishedat)))))
