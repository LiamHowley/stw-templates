(in-package :cl-user)

(defpackage template
  (:use :cl)

  (:import-from
   :contextl
   :deflayer
   :define-layered-class
   :define-layered-function
   :define-layered-method
   :partial-class-base-initargs
   :with-active-layers)

  (:import-from
   :stw.util
   :awhen
   :aif
   :self)

  (:import-from
   :djula
   :compile-template*
   :render-template*)
  
  (:import-from
   :cl-comp
   :define-base-class
   :serialize
   :serialized-p
   :base-class
   :comp-base-layer
   :comp-base-class
   :comp-direct-slot-definition
   :comp-layer-context
   :slot-definition-class
   :initialize-in-context
   :filter-slots-by-type
   :object-to-plist)

  (:export
   :template
   :template-context-class
   :template-slot-definition
   :template-layer
   :template-class

   :define-template-class
   :render-template
   :compiled-template
   :compile-template))
