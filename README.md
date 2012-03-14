An iBooks style book shelf

Features:

1. drag & drop
2. scroll up/down while draging
3. add & remove animation
4. custom header (add a search bar or anything you want)

TODO:

1. does not support orientation change now, it's fixed Portrait or landscape (doesn't have a convenient method to reload the parameters in the init method.)
2. the init method need too many parameters now. I will move all of them to GSBookShelfViewDataSource protocol methods, and this will help a lot when orientation changes, but maybe there'll be too many protocol methods.