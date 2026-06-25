(asdf:defsystem "declare-env"
  :description "Declarative environment-variable wrangling"
  :author "Judah Sotomayor"
  :license "MIT"
  :version (:read-file-form "VERSION.txt")
  :depends-on (:uiop :alexandria)
  :components ((:file "main")
               (:file "validators")))
