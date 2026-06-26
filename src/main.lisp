(defpackage declare-env
  (:use
   #:cl)
  (:local-nicknames (:util :serapeum/bundle))
  (:export
   #:declare-env))

(in-package #:declare-env)

(defmacro declare-env (env &body vars)
  "Define a collection of environment VARS under NAME.
Each variable will be defconstant'd."
  (setf (get env 'vars) nil)
  (let* ((defconstants nil)
         (environment-names nil)
         (push-var (util:curry #'apply
                               (lambda (var description &optional default (validator '#'identity))
                                 (let ((constant-name (constant-name var env))
                                       (environment-name (environment-name var env)))
                                   (push `(defconstant ,constant-name
                                            (funcall ,validator
                                                     (util:string+ (or (uiop:getenv ,environment-name) ,default)))
                                            ,description)
                                         defconstants)
                                   (push (list constant-name environment-name default description) (get env 'declare-env::vars))
                                   (push environment-name environment-names))))))

    (mapcar push-var vars)
    `(progn ,@defconstants
            ',environment-names)))


(defun constant-name (var &optional env)
  "Generate the internal name for VAR inside ENV."
  (declare (ignore env))
  var)

(defun environment-name (var &optional env)
  "Generate the external environment variable name for VAR inside ENV."
  (substitute-if-not #\_ #'alphanumericp
                     (util:fmt "~@:(~@[~a_~]~a~)" env var)))

(defun document-variable (var-list)
  "Generate the doclines for VAR, including DESCRIPTION if available.
If DEFAULT is provided, illustrate it in the variable."
  (destructuring-bind (constant-name environment-name default description) var-list
    (declare (ignore constant-name))
      (util:fmt "~@[#~a~%~]~a=~@[~a~]~%~%" description environment-name default)))

(defun document-env (env)
  (apply #'concatenate 'string
         (mapcar #'document-variable (get env 'declare-env::vars))))
