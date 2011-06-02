HBCollections
=============
Objective-C categories for functional data structure traversal with blocks.  The interface was inspired by [Javascript Array Iteration Methods][javascript-array-iteration-methods].  The implementation was inspired by [Mike Ash's][mikeash] [Implementating Fast Enumeration Friday Q&A][implementing-fast-enumeration-qa].

Why
---
Your loop bodies and if predicates become reusable blocks, fine-grained code reuse points with which you can assemble larger systems.

Simple Examples
---------------
Instead of [iterating your array with a for loop][iterating-array-for], you can [enumerate your array][enumerate-array].
Instead of [totalling your array with a for loop][totalling-array-for], you can [reduce your array to a total][reduce-array-total].

Compatibility
-------------
Most methods return chainable `NSEnumerator`s, so you can [break][], then [filter][break-filter], then [map][break-filter-map], and still use a [fast enumeration for loop][break-filter-map-fast-enumeration] (of course, you could always just [reduce][break-filter-map-reduce] or [enumerate][break-filter-map-enumerate] it).
Arrays, sets, and enumerators use the same API, [so your blocks can interoperate][array-set-enumerator-share-block] (unlike [foundation block enumeration][foundation-block-no-share]).

Convenience
-----------
Although you can easily [reduce an array to a dictionary][reduce-array-to-dictionary], there is a convenience method to do it for you.
Foundation APIs allow you to [convert an enumerator to an array][enumerator-to-array], but there are convenience methods to convert to a [mutable array][enumerator-to-mutable-array], [set][enumerator-to-mutable-set], and [mutable set][enumerator-to-mutable-set].

Implementation
--------------
There is a [protocol][HBCollection-h] in case you have your own data structure you want to traverse. Under the hood, everything uses [fast enumeration][fast-enumeration] and uses just one memory buffer for intermediate storage.

License
-------
LGPL.

[javascript-array-iteration-methods]:https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Array#Iteration_methods
[mikeash]:https://github.com/mikeash
[implementing-fast-enumeration-qa]:http://www.mikeash.com/pyblog/friday-qa-2010-04-16-implementing-fast-enumeration.html
[iterating-array-for]:
[enumerate-array]:
[totalling-array-for]:
[reduce-array-total]:
[break]:
[break-filter]:
[break-filter-map]:
[break-filter-map-reduce]:
[break-filter-map-enumerate]:
[array-set-enumerator-share-block]:
[foundation-block-no-share]:
[enumerator-to-array]:http://developer.apple.com/library/mac/#documentation/cocoa/reference/foundation/Classes/NSEnumerator_Class/Reference/Reference.html#//apple_ref/occ/instm/NSEnumerator/allObjects
[enumerator-to-mutable-array]:
[enumerator-to-set]:
[enumerator-to-mutable-set]:
[HBCollection-h]:
[fast-enumeration]:http://developer.apple.com/library/mac/#documentation/cocoa/Conceptual/ObjectiveC/Chapters/ocFastEnumeration.html
