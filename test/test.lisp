(defpackage template.test
  (:use :cl
	:parachute
	:template)
  (:import-from :contextl
		:with-active-layers)
  (:export :sanity-test))

(in-package template.test)

;;;; setting up

(define-template-class page ()
  (title name)
  (:template . ("stw-templates" "test/templates1/index.html")))

(define-template-class other-pages ()
  (title name)
  (:template . ("stw-templates" "test/templates2/index.html")))


(define-test sanity-test
  (of-type djula::compiled-template (compiled-template (find-class 'page)))
  (is string=
      "<!DOCTYPE html>
<html>
<head>
  <meta charset=\"utf-8\">
  <title>Welcome to the site of Foo!</title>
  <link rel=\"stylesheet\" type=\"text/css\" media=\"screen\" href=\"/css/main.css\">
</head>
<body>
  <div id=\"my-first-block\">
  
<div id=\"main\">
  Welcome to <a href=\"https://github.com/liamhowley/stw-templates\">Foo</a>!
</div>

  </div>
</body>
</html>
"
      (with-active-layers (template-layer)
	(render-template (make-instance 'page :title "Welcome to the site of Foo!" :name "Foo"))))
  (of-type djula::compiled-template (compiled-template (find-class 'other-pages)))
  (is string=
      "<!DOCTYPE html>
<html>
<head>
  <meta charset=\"utf-8\">
  <title>Welcome to the site of Foo!</title>
  <link rel=\"stylesheet\" type=\"text/css\" media=\"screen\" href=\"/css/main.css\">
</head>
<body>
  <div id=\"my-first-block\">
  
<div id=\"main\">
  Welcome to <a href=\"https://github.com/liamhowley/stw-templates\">Foo</a>!
</div>

  </div>
</body>
</html>
"
      (with-active-layers (template-layer)
	(render-template (make-instance 'other-pages :title "Welcome to the site of Foo!" :name "Foo")))))
