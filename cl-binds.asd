;;;; cl-binds.asd

(asdf:defsystem #:cl-binds
  :serial t
  :description "Allows binding object A to object B so the object A's slots
will act like they are from object B, reading from and writing to object B"
  :author "farzadbekran@gmail.com"
  :license "Free Software, you can do whatever you want with it."
  :depends-on (#:cl-attribs)
  :components ((:file "package")
               (:file "cl-binds")))

