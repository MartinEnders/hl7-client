;;;; hl7-client.lisp

;; Copyright (c) 2015, Martin R. Enders
;; All rights reserved.

;; Redistribution and use in source and binary forms, with or without modification,
;; are permitted provided that the following conditions are met:

;; 1. Redistributions of source code must retain the above copyright notice,
;;    this list of conditions and the following disclaimer.

;; 2. Redistributions in binary form must reproduce the above copyright notice,
;;    this list of conditions and the following disclaimer in the documentation
;;    and/or other materials provided with the distribution.

;; 3. Neither the name of the copyright holder nor the names of its contributors
;;    may be used to endorse or promote products derived from this software without
;;    specific prior written permission.

;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 'AS IS' AND ANY
;; EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
;; OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
;; SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
;; OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
;; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(in-package #:hl7-client)

;;; "hl7-client" goes here. Hacks and glory await!

(defun get-hl7-test-message (&optional (message-control-id (random 10000)))
  (format nil "~{~A~}" (list (format nil "MSH|^~~\\&|Sending-App|Sending-Facility|Receiving-App|Receiving-Facility|20150101195400||ADT^A02|~A|P|2.2" message-control-id)
			     #\Return
			     "EVN|A02|20150101195400"
			     #\Return
			     "PID|||3216549870||Testpatient^Testvorname||19500505|M"
			     #\Return
			     "PV1||s|BCA^B6^07||||||||||||||||1234567890|||||K|||||||||||||||AM|||||20150101195400|"
			     #\Return)))

(defun get-hl7-test-message-list (&optional (number-of-messages 10))
  (loop for x from 0 upto number-of-messages collect  (get-hl7-test-message (format nil "~A-~A" x (random 10000)))))


(defun mllp-send-message (stream line)
  "Print Message with MLLP Envelope to stream"
  (princ (code-char 11) stream)
  (princ line stream)
  (princ (code-char 28) stream)
  (princ (code-char 13) stream))
	  
(defun send (server port message-or-message-list)
  (let ((socket (usocket:socket-connect server port))
	(messages (if (listp message-or-message-list)
		      message-or-message-list
		      (list message-or-message-list))))
    (unwind-protect
	 (progn

	   (loop for message in messages
		collect (progn 
			  ;; send request
			  (mllp-send-message (usocket:socket-stream socket) (format nil "~A" message))
			  (force-output (usocket:socket-stream socket))
			  
			  ;; read response
			  (with-output-to-string (s)
			    ;; Remove MLLP-Envelope at beginning of Message
			    (when (char= (peek-char nil (usocket:socket-stream socket) nil nil) (code-char 11))
			      (read-char (usocket:socket-stream socket) nil nil))

			    
			    ;; Read ACK from stream and ignore end of MLLP-Envelope
                            (loop for char = (read-char (usocket:socket-stream socket) nil nil)
			       while (and char 
					;(peek-char nil (usocket:socket-stream socket) nil nil)
			       		  (listen (usocket:socket-stream socket))
			       		  ;; Stop looping when end of MLLP-Envelope is reached.
			       		  (not (and
			       		  	(char= char (code-char 28)) 
			       		   	(char= (peek-char nil (usocket:socket-stream socket) nil nil) (code-char 13)))))

			       do (progn (princ char s))
			       ;; Remove last character from MLLP Envelope
			       finally (read-char (usocket:socket-stream socket) nil nil))))))

				 
		

      (progn 
	(close (usocket:socket-stream socket))
	(usocket:socket-close socket)))))
