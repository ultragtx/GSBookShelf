#GSBookShelf

An iBooks-inspired bookshelf control.

Supports animated deletion, reordering, and addition.

---

Attention:

1. This code should be compiled with ARC turned on;

---

Features:

1. drag & drop
2. scroll up/down while draging
3. add & remove animation
4. custom header (add a search bar or anything you want)
5. **[NEW 12.04.03]** The demo supports oritation changing now, but I'm too lazy to make a new cell image. Just reset the number of books in each cell.(3 when portrait, 4 when landscape).


---

How TO:

1. Just take a look at the demo.
2. bookView and shelfCell are just UIViews. So you can cutomize them almost whatever you want. But the frame of each view is fixed, if you want to have different size of bookView, you can try adding your content on a transparent UIView.
3. To enable reusing for bookViews and cells, add the "GSBookView" / "GSBookShelfCell" protocols. (You'd better do this, perfromance will be a lot better).
4. **[NEW 12.04.03]** To support oritation change, you should call the reload method and return different values (if necessary) in the delegate method with different orientation.
5. **[NEW 12.04.03]** For more information about the data GSBookShelf need for layout, take a look at the "[comments.png](https://github.com/ultragtx/GSBookShelf/blob/ReadyTo/BookShelf/comments.png?raw=true)" (also available in the project)

---

TODO:

1. **[Done]** ~~does not support orientation change now, it's fixed Portrait or landscape (doesn't have a convenient method to reload the parameters which was set in the init method.)~~ 

2. **[Done]** ~~the init method need too many parameters now. I will move all of them to GSBookShelfViewDataSource protocol methods, and this will help a lot when orientation changes, but maybe there'll be too many protocol methods.~~

3. **[NEW 12.04.03]** Need some animation for cell when the orientation change.

4. **[NEW 12.05.14]** Go to a proper row when orientation change. (Always go to top currently)

---

Demo:(Be Patient, some gifs' size > 1M)

![image](https://github.com/ultragtx/ultragtx.github.com/blob/master/images/Move_s.gif?raw=true)
![image](https://github.com/ultragtx/ultragtx.github.com/blob/master/images/Add_s.gif?raw=true)
![image](https://github.com/ultragtx/ultragtx.github.com/blob/master/images/Delete_s.gif?raw=true)

---
Please support if you like it!

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=ultragtx%40gmail%2ecom&lc=US&item_name=GSBookShelf%20Improve%20Fund&no_note=0&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHostedGuest">
<img src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!" />
</a>
