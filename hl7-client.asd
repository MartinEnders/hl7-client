;;;; hl7-client.asd

(asdf:defsystem #:hl7-client
  :serial t
  :description "Describe hl7-client here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :depends-on (:usocket)
  :components ((:file "package")
               (:file "hl7-client")))

