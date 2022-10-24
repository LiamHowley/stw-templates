(defsystem #:stw-templates
  :author "Liam Howley <liam.howley@thespanningtreeweb.ie>"
  :license "MIT"
  :depends-on ("cl-comp"
	       "contextl"
	       "stw-utils"
	       "djula")
  :description "Bind string templates and CLOS objects within defined contexts."
  :serial t
  :components ((:file "package")
	       (:file "template"))
  :long-description
  #.(uiop:read-file-string
     (uiop:subpathname *load-pathname* "docs/README.org"))
    :in-order-to ((test-op (load-op :stw-template-test))))
