(defpackage declare-env.validators
  (:use #:cl)
  (:export
   #:validate-port
   #:validation-error))
(in-package #:declare-env.validators)

(defconstant ^max-port-number^ 65535
  "The largest possible TCP port number. Largest U16.")

(define-condition validation-error (error)
  ((value :initarg :value :reader ve-value)
   (context :initarg :context :reader ve-context :initform ""))
  (:report (lambda (error stream)
             (format stream
                     "Value ~a does not match validator.~%~a" 
                     (ve-value error)
                     (ve-context error)))))

(defun validation-error (value context)
  "Throw a validation-error with VARIABLE, VALUE, CONTEXT."
  (error 'validation-error :value value :context context))

(defun validate-port (str)
  "Parse STR into a port or throw a validation error."
  (with-simple-restart (set-alternative "Set an alternative environment value")
    (let ((port (ignore-errors (parse-integer str))))
      (unless (and port (<= 1 port ^max-port-number^))
        (validation-error str "Not a valid port number in the range 1-65535."))
      port)))

