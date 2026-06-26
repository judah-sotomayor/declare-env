(defpackage declare-env
  (:use
   #:cl
   #:alexandria)
  (:export
   #:declare-env))

(in-package #:declare-env)

;; (declare-env my-app
;;   (database "The database connection string.")
;;   (redis "The redis connection string.")
;;   (port "The TCP port to listen on." "800" #'parse-integer))

(defmacro declare-env (env &body vars)
  "Define a collection of environment VARS under NAME.
Each variable will be defconstant'd."
  (setf (get env 'vars) nil)
  (let* ((defconstants nil)
         (push-var (curry #'apply
                          (lambda (var description &optional default (validator '#'identity))
                            (let ((constant-name (constant-name var env))
                                  (environment-name (environment-name var env)))
                              (push `(defconstant ,constant-name
                                       (funcall ,validator
                                                ;; XXX Serapeum would make this a bit easier with (string+) instead of the or
                                                (or (uiop:getenv ,environment-name) ,default ""))
                                       ,description)
                                    defconstants)
                              (push (list constant-name environment-name default description) (get env 'declare-env::vars)))))))

    (mapcar push-var vars)
    `(progn ,@defconstants)))


(defun constant-name (var &optional env)
  "Generate the internal name for VAR inside ENV."
  (declare (ignore env))
  var)

(defun environment-name (var &optional env)
  "Generate the external environment variable name for VAR inside ENV."
  (print var)
  (substitute-if-not #\_ #'alphanumericp
                     ;; XXX Serapeum would make this a bit easier with (string+ env #\_ var)
                     (format nil "~@:(~@[~a_~]~a~)" env var)))

(defun document-variable (var-list)
  "Generate the doclines for VAR, including DESCRIPTION if available.
If DEFAULT is provided, illustrate it in the variable."
  (destructuring-bind (constant-name environment-name default description) var-list
    (declare (ignore constant-name))
      (format nil "~@[#~a~%~]~a=~@[~a~]~%~%" description environment-name default)))

(defun document-env (env)
  (apply #'concatenate 'string
         (mapcar #'document-variable (get env 'declare-env::vars))))
