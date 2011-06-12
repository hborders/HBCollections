HBCollections
=============
Objective-C categories for functional data structure traversal with blocks.  The interface was inspired by [Javascript Array Iteration Methods][javascript-array-iteration-methods].  The implementation was inspired by [Mike Ash's][mikeash] [Implementating Fast Enumeration Friday Q&A][implementing-fast-enumeration-qa].

Why
---
Your loop bodies and if predicates become reusable blocks, fine-grained code reuse points with which you can assemble larger systems.

Simple Examples
---------------
Instead of iterating your array with a for loop, you can [enumerate your array][enumerate-array].
Instead of totalling your array with a for loop, you can [reduce your array to a total][reduce-array-total].

Compatibility
-------------
Most methods return chainable `NSEnumerator`s, so you can [map, then add filtering, then add breaking, and still use a fast enumeration for loop (of course, you could always just reduce or enumerate it)][break-filter-map-enumerate-simple]. ([A more complex example][break-filter-map-enumerate]).
Arrays, sets, and enumerators use the same API, [so your blocks can interoperate, unlike foundation block enumeration)][share-blocks].

Convenience
-----------
Although you can easily [reduce an array to a dictionary][reduce-array-to-dictionary], there is a convenience method to do it for you.
Foundation APIs allow you to [convert an enumerator to an array][enumerator-to-array], but HBCollections gives you convenience methods to convert to a [mutable array, set, and mutable set][convenience].

Implementation
--------------
There is a [protocol][HBCollection-h] in case you have your own data structure you want to traverse. Under the hood, everything uses [fast enumeration][fast-enumeration] and uses just one memory buffer for intermediate storage.

License
-------
LGPL.

[javascript-array-iteration-methods]:https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Array#Iteration_methods
[mikeash]:https://github.com/mikeash
[implementing-fast-enumeration-qa]:http://www.mikeash.com/pyblog/friday-qa-2010-04-16-implementing-fast-enumeration.html
[enumerate-array]:https://github.com/hborders/HBCollections/blob/master/Examples/HBEnumerateComparison.m
[reduce-array-total]:https://github.com/hborders/HBCollections/blob/master/Examples/HBReduceComparison.m
[break-filter-map-enumerate-simple]:https://github.com/hborders/HBCollections/blob/master/Examples/HBBreakFilterMapSimple.m
[break-filter-map-enumerate]:https://github.com/hborders/HBCollections/blob/master/Examples/HBBreakFilterMapComparison.m
[share-block]:https://github.com/hborders/HBCollections/blob/master/Examples/HBEnumerateComparison.m
[reduce-array-to-dictionary]:https://github.com/hborders/HBCollections/blob/master/Examples/HBReduceComparison.m
[enumerator-to-array]:http://developer.apple.com/library/mac/#documentation/cocoa/reference/foundation/Classes/NSEnumerator_Class/Reference/Reference.html#//apple_ref/occ/instm/NSEnumerator/allObjects
[convenience]:https://github.com/hborders/HBCollections/blob/master/Examples/HBConvenience.m
[HBCollection-h]:https://github.com/hborders/HBCollections/blob/master/Source/HBCollection.h
[fast-enumeration]:http://developer.apple.com/library/mac/#documentation/cocoa/Conceptual/ObjectiveC/Chapters/ocFastEnumeration.html
