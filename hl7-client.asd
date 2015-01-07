;;;; hl7-client.asd

(asdf:defsystem #:hl7-client
  :serial t
  :description "hl7-client - send HL7-Messages over TCP/IP with MLLP"
  :author "Martin Enders <martin@martin-enders.de>"
  :license ""
  :depends-on (:usocket)
  :components ((:file "package")
               (:file "hl7-client")))

