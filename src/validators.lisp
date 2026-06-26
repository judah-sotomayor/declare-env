(defpackage declare-env.validators
  (:use #:cl)
  (:local-nicknames (:util :serapeum/bundle))
  (:export
   #:validation-error
   #:validate-port
   #:validate-boolean))
(in-package #:declare-env.validators)

(defconstant ^max-port-number^ 65535
  "The largest possible TCP port number. Largest U16.")

(define-condition validation-error (error)
  ((value :initarg :value :reader ve-value)
   (context :initarg :context :reader ve-context :initform ""))
  (:report (lambda (error stream)
             (format stream
                     "Value \"~a\" does not match validator.~%~a" 
                     (ve-value error)
                     (ve-context error)))))

;; TODO Add context field ig, and make sure it reports pretty
(define-condition validator-style (style-warning)
  ()
  (:documentation "Warning class for validator definitions."))

(defun validation-error (value context)
  "Throw a validation-error with VARIABLE, VALUE, CONTEXT."
  (error 'validation-error :value value :context context))

(defun %prompt ()
  "Prompt for and return a new string to pass to a function."
  (format *query-io* "New value: ")
  (finish-output *query-io*)
  (list (read-line)))

(defmacro define-validator (name &body body)
  "Define a simple validator called NAME.
A doc-string may be provided after NAME.

BODY is executed in the context of a USE-VALUE restart,
which can be used to provide an alternative value should the validation fail.
A single parameter STR is bound around BODY.
"
  (unless (util:string-prefix-p "validate-" (symbol-name name))
    (signal 'validator-style :context "Validators should begin with validate-"))

  (multiple-value-bind (body remaining-forms doc-string)
      (util:parse-body body :documentation t)
    (declare (ignore remaining-forms))
    `(defun ,name (str)
       ,(or doc-string "")
       (declare (ignorable str)
                (string str))
       (restart-case

           ,@body

         (use-value (str)
           :report "Provide a replacement string."
           :interactive %prompt
           (,name str))))))

(define-validator validate-port
  "Parse STR into a port or throw a validation error."
  (let ((port (ignore-errors (parse-integer str))))
    (unless (and port (<= 1 port ^max-port-number^))
      (validation-error str "Not a valid port number in the range 1-65535."))
    port))


(define-validator validate-bool
  "Parse STR into a boolean value or throw a validation error."
  (util:string-case (string-downcase str) 
    (("yes" "y" "true"  "1") t)
    (("no"  "n" "false" "0" "") nil)
    (t (validation-error str "Invalid value assigned to boolean!"))))

