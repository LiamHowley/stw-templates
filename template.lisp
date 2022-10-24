(in-package template)


(defclass template-context-class (comp-layer-context)
  ())

(deflayer template-layer (comp-base-layer)
  ()
  (:metaclass template-context-class))


(define-layered-class base-template-class
  :in template-layer (base-class)
  ((template :initarg :template
	     :reader template
	     :documentation "The slot template must be assigned a list of '(<system-name> <template-file-address> during initialization. A call is made to ASDF:SYSTEM-RELATIVE-PATHNAME to get the relative directory to work with. If the file exists, it Will be compiled to type DJULA:COMPILED-TEMPLATE and the slot mutated."))
  (:documentation "Defining metaclass for TEMPLATE-CLASS. With slot template."))

(defmethod partial-class-base-initargs append ((class base-template-class))
  '(:template))

(defclass template-slot-definition (comp-direct-slot-definition)
  ())

(defmethod slot-definition-class ((layer-metaclass template-context-class))
  'template-slot-definition)

(define-layered-class template-class
  :in-layer template-layer (comp-base-class base-template-class)
  ())


(defmacro define-template-class (name &body body)
  "Wrapper on DEFINE-BASE-CLASS."
  (unless (serialized-p (car body))
    (push 'serialize (car body)))
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (define-base-class ,name
       :in template-layer
       ,@body
       (:metaclass template-class))))



(define-layered-method initialize-in-context
  :in template-layer ((class base-template-class) &key template)
  (awhen (apply #'asdf:system-relative-pathname template)
    (when (probe-file self)
      (setf (slot-value class 'template) self)
      (compile-template class))))


(define-layered-function compile-template (template)
  (:method
      :in template-layer ((class base-template-class))
    (with-slots (template) class
      (setf template (compile-template* template)))))


(define-layered-function render-template (template-class &optional stream args)

  (:method
      :in template-layer ((template-class template-class) &optional stream args)
    (with-slots (template) template-class
      (apply #'djula:render-template* template stream args)))

  (:method
      :in template-layer ((instance serialize) &optional stream args)
    (declare (ignore args))
    (render-template (class-of instance) stream
		     (cdr (object-to-plist instance :filter 'template-slot-definition)))))
