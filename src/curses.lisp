(in-package :tube)

(defun init-screen ()
  (with-screen (scr :input-echoing nil :cursor-visible t :enable-colors t :enable-function-keys t :input-blocking t :stacked t)
    (let* ((field1 (make-instance 'field :name :f1 :title "Forename" :position '(3 20) :width 15
                                         :style '(:background (:simple-char #\.)
                                                  :selected-background (:simple-char #\.))))
           (ddm1 (make-instance 'crt:dropdown :name :ddm1 :title "Select..." :items '(foo bar baz quux) :width 15
                                              :style '(:selected-foreground (:attributes (:reverse) :fgcolor :red))
                                              :position '(5 20)))
           (ddm2 (make-instance 'crt:dropdown :name :ddm1 :title "Select..." :items '(common-lisp scheme clojure elisp)
                                              :width 15
                                              :style '(:selected-foreground (:attributes (:reverse)))
                                              :border t
                                              :position '(6 19)))
           (label1 (make-instance 'label :name :l1 :reference :f1    :width 18 :position '(3 1)))
           (label2 (make-instance 'label :name :l2 :title "Variable" :width 18 :position '(5 1)))
           (label3 (make-instance 'label :name :l3 :title "Language" :width 18 :position '(7 1)))
           (form (make-instance 'form :elements (list field1 ddm1 ddm2 label1 label2 label3) :window scr)))
      (let ((val (edit form)))
        (clear scr)
        (format scr "~S~%" val)
        (if val
            (progn
              (mapc
               #'(lambda (name)
                 (let ((element (find-element form name)))
                   (format scr "~5A ~18A ~20A~%" name (croatoan:title element) (value element))))
               (list :f1 :ddm1 :ddm2)))
            (format scr "nil"))
        (refresh scr)
        (wait-for-event scr)))))
