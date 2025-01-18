(defsystem "tube"
  :version "0.0.1"
  :author "goosecoid"
  :license "MIT"
  :depends-on ("binding-arrows"
               "xmls"
               "dexador"
               "str"
               "mito"
               "local-time"
               "croatoan")
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "xml")
                 (:file "db")
                 (:file "curses")
                 (:file "yt-dlp")
                 (:file "main")))))
