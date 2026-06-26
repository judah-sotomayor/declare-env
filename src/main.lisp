(defpackage declare-env
  (:use
   #:cl)
  (:local-nicknames (:util :serapeum/bundle))
  (:export
   #:declare-env
   #:document-environment))

(in-package #:declare-env)

(defmacro declare-env (env &body vars)
  "Define a collection of environment VARS in ENV.
Each entry in VARS must be a list:
 (NAME DESCRIPTION &optional VALIDATOR DEFAULT)
NAME will be translated for the shell, swapping dashes for underscores and prefixing ENV.
A NAME \"db-conn\" with ENV=myapp will define a lisp constant DB-CONN
 which reads from environment variable MYAPP_DB_CONN.

DESCRIPTION is used to generate documentation for each variable.
It becomes the docstring for the lisp constant and exports with document-environment.

VALIDATOR is a function that takes a single string as an argument.
Defaults to #'identity.
VALIDATOR must return the value of the variable parsed into the form the user wants in the constant.
For example, the VALIDATE-BOOL function returns either T or NIL according to its input:
T for yes, y, true, 1 and NIL for no, n, false, 0, and \"\".
VALIDATOR ought to signal an error if the environment variable is set to a bad value.

DEFAULT is a fallback value for a variable that is not defined in the environment.
For example, a webserver may wish to define a default port to listen on.
DEFAULT should be used with care to avoid checking secrets into the codebase.

This macro returns a list of all the variables accepted from the shell environment at startup."
  
  (progn
      (setf (get env 'vars) nil)
     (let* ((defconstants nil)
            (environment-names nil)
            (push-var (util:curry #'apply
                                  (lambda (var description &optional (validator '#'identity) default)
                                    (let ((constant-name (constant-name var env))
                                          (environment-name (environment-name var env)))
                                      (push `(defconstant ,constant-name
                                               (funcall ,validator
                                                        (util:string+ (or (uiop:getenv ,environment-name) ,default)))
                                               ,description)
                                            defconstants)
                                      (push (list constant-name environment-name description default) (get env 'declare-env::vars))
                                      (push environment-name environment-names))))))

       (mapcar push-var vars)
       `(progn ,@defconstants
               ',environment-names))))


(defun constant-name (var-name &optional env)
  "Generate the internal name for VAR-NAME inside ENV."
  (declare (ignore env))
  var-name)

(defun environment-name (var-name &optional env)
  "Generate the external environment variable name for VAR-NAME inside ENV."
  (substitute-if-not #\_ #'alphanumericp
                     (util:fmt "~@:(~@[~a_~]~a~)" env var-name)))

(defun document-variable (var)
  "Generate the doclines for VAR, including DESCRIPTION if available.
If DEFAULT is provided, illustrate it in the variable."
  (destructuring-bind (constant-name environment-name description default) var
    (declare (ignore constant-name))
      (util:fmt "~@[#~a~%~]~a=~@[~a~]~%~%" description environment-name default)))

(defun document-environment (env)
  (apply #'concatenate 'string
         (mapcar #'document-variable (get env 'declare-env::vars))))
