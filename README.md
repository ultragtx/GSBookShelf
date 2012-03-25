An iBooks style book shelf

Attention:

1. This code should be compiled with ARC turned on;

Features:

1. drag & drop
2. scroll up/down while draging
3. add & remove animation
4. custom header (add a search bar or anything you want)


How TO:

1. Just take a look at the demo.
2. bookView and shelfCell are just UIViews. So you can cutomize them almost whatever you want. But the frame of each view is fixed, if you want to have different size of bookView, you can try adding your content on a transparent UIView.
3. To enable reusing for bookViews and cells, add the <GSBookView> / <GSBookShelfCell> protocols. (You'd better do this, perfromance will be a lot better).

TODO:

1. does not support orientation change now, it's fixed Portrait or landscape (doesn't have a convenient method to reload the parameters which was set in the init method.)
2. the init method need too many parameters now. I will move all of them to GSBookShelfViewDataSource protocol methods, and this will help a lot when orientation changes, but maybe there'll be too many protocol methods.

Demo:

![image](https://github.com/ultragtx/ultragtx.github.com/blob/master/images/Move_s.gif?raw=true)
![image](https://github.com/ultragtx/ultragtx.github.com/blob/master/images/Add_s.gif?raw=true)
![image](https://github.com/ultragtx/ultragtx.github.com/blob/master/images/Delete_s.gif?raw=true)