;;;; cl-binds.asd

(asdf:defsystem #:cl-binds
  :serial t
  :description "Allows binding object A to object B so the object A's slots
will act like they are from object B, reading and writing to object B"
  :author "Farzad Bekran"
  :license "Free Software"
  :depends-on (#:cl-attribs)
  :components ((:file "package")
               (:file "cl-binds")))

