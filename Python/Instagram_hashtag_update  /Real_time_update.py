#Implement real-time photo updates in MongoDB by setting up tornado server

import tornado.ioloop
import tornado.web
import instagram
 
#Use current as the default when constructing an asynchronous object
class BaseHandler(tornado.web.RequestHandler):
    def get_current_user(self):
        return self.get_secure_cookie("1412145795.080dbbd.6fd042641d04471a937b2c47d1301ca9")
 
#Register the given handler to receive the given events
class InstagramAuthHandler(BaseHandler, instagram.InstagramMixin):
    @tornado.web.asynchronous
    def get(self):
        if self.get_argument("code", None):
            self.get_authenticated_user(self.async_callback(self._on_auth))
            return
        self.authorize_redirect()
 
    def _on_auth(self, user):
        if not user:
            raise tornado.web.HTTPError(500, "Instagram auth failed")
        self.set_secure_cookie(
            "1412145795.080dbbd.6fd042641d04471a937b2c47d1301ca9",
            user["1412145795.080dbbd.6fd042641d04471a937b2c47d1301ca9"]
        )
        self.redirect(self.get_argument("next", "/"))
 
#Call the given callback on the next I/O loop iteration 
class MainHandler(BaseHandler, instagram.InstagramMixin):
    @tornado.web.authenticated
    @tornado.web.asynchronous
    def get(self):
        self.instagram_request(
            "https://api.instagram.com/v1/tags/columbia/media/recent?access_token=1412145795.080dbbd.6fd042641d04471a937b2c47d1301ca9",
            access_token=self.current_user,
            callback=self.async_callback(self._on_request))
 
    def _on_request(self, response):
        self.finish(response)
 
#Return a global IOLoop instance
application = tornado.web.Application([
        (r"/", MainHandler),
        (r"/login", InstagramAuthHandler)
    ],
    cookie_secret="1412145795.080dbbd.6fd042641d04471a937b2c47d1301ca9",
    instagram_client_id="080dbbdb579a4fcd80df8b5b4dac98c2",
    instagram_client_secret="3b039456c3e54d49978ca5d15369b07c",
    login_url="https://instagram.com/accounts/login/"
)
 
if __name__ == "__main__":
    application.listen(8888)
    tornado.ioloop.IOLoop.instance().start()