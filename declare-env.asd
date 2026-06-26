(asdf:defsystem "declare-env"
  :description "Declarative environment-variable wrangling"
  :author "Judah Sotomayor"
  :license "MIT"
  :version (:read-file-form "VERSION.txt")
  :depends-on (:uiop :serapeum)
  :serial t
  :pathname "src/"
  :components ((:file "main")
               (:file "validators"))
  :in-order-to ((test-op (test-op "declare-env/tests"))))

(asdf:defsystem "declare-env/tests"
  :version (:read-file-form "VERSION.txt")
  :depends-on (:declare-env :fiasco)
  :perform (asdf:test-op (o s)
                         (unless (symbol-call :declare-env-tests :run-declare-env-tests)
                           (error "Tests failed")))
  :serial t
  :pathname "tests/"
  :components ((:file "main")
               (:file "validators")))
