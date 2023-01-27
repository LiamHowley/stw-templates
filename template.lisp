(in-package template)


(defclass template-context-class (comp-layer-context)
  ())

(deflayer template-layer (comp-base-layer)
  ()
  (:metaclass template-context-class))

(defgeneric compiled-template (template)
  (:documentation "Accessor for TEMPLATE slot of the BASE-TEMPLATE-CLASS")
  (:method (template) nil))

(define-layered-class base-template-class
  :in template-layer (base-class)
  ((template :initarg :template
	     :reader compiled-template
	     :special t
	     :documentation "The slot template must be assigned a list of 
(<system-name> <template-file-address>) during initialization. A call is 
made to ASDF:SYSTEM-RELATIVE-PATHNAME to get the relative directory to 
work with. If the file exists, it Will be compiled to type 
DJULA:COMPILED-TEMPLATE and the slot mutated."))
  (:documentation "Defining metaclass for TEMPLATE-CLASS. With slot template."))

(defmethod (setf compiled-template)
    (new-value (class base-template-class))
  (with-slots (template) class
    (etypecase template
      (cons
       (awhen (apply #'asdf:system-relative-pathname new-value)
	 (when (open self :direction :probe :if-does-not-exist :create)
	   (setf (slot-value class 'template) self)
	   (compile-template class))))
      (pathname
       (compile-template class))
      (djula::compiled-template 
       template))))


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
  (setf (compiled-template class) template))


(define-layered-function compile-template (template)
  (:method
      :in template-layer ((class base-template-class))
    (with-slots (template) class
      (setf template (compile-template* template)))))


(define-layered-function render-template (template-class &optional stream args)
  (:documentation "Render template accepts either a TEMPLATE-CLASS or an 
instance of TEMPLATE-CLASS, and two optional arguments, a stream and a plist of 
(:<template variable> <value>). When dispatching on an instance, the optional 
argument args is ignored as the arguments are derived from the slots of type 
TEMPLATE-SLOT-DEFINITION.

If the class of the object is instead passed to RENDER-TEMPLATE the optional 
args must contain the aforementioned plist of template variables and values.")

  (:method
      :in template-layer ((template-class template-class) &optional stream args)
    (with-slots (template) template-class
      (apply #'djula:render-template* template stream args)))

  (:method
      :in template-layer
      ((instance serialize) &optional stream (args (object-to-plist instance)))
    ;; As object-to-plist uses the first initarg available in the list of
    ;; slot initargs, it works despite the possible mismatch between
    ;; slot names and template variables.
    (render-template (class-of instance) stream args)))
