(defsystem #:stw-template-test
    :description "A simple sanity test for stw-templates."
    :depends-on ("stw-templates" "contextl" "parachute")
    :components ((:file "test"))
    :perform (asdf:test-op (op c) (uiop:symbol-call :parachute :test :template.test)))
