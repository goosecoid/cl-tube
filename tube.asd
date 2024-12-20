(defsystem "tube"
  :version "0.0.1"
  :author "goosecoid"
  :license "MIT"
  :depends-on ("binding-arrows"
               "xmls"
               "dexador"
               "str")
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "main")))))
