#This function is used in setting up tornado server

import tornado.web
import tornado.auth
import tornado.escape
 
from urlparse import urlparse, urlunparse, parse_qs
from urllib import urlencode
 
 
class InstagramMixin(tornado.auth.OAuth2Mixin):
    _OAUTH_AUTHORIZE_URL = "https://api.instagram.com/oauth/authorize"
    _OAUTH_ACCESS_TOKEN_URL = "https://api.instagram.com/oauth/access_token"
    _INSTAGRAM_BASE_URL = "https://api.instagram.com/v1"
 
    def get_authenticated_user(self, callback):
        url = self._oauth_request_token_url(
            redirect_uri=strip_qs_params(self.request.full_url(), ["code"]),
            client_id=self._instagram_client_id,
            client_secret=self._instagram_client_secret,
            code=self.get_argument("code"),
            extra_params={
                "grant_type": "authorization_code",
            }
        )
        url, params = url.split("?")
        self.get_auth_http_client().fetch(
            url,
            method="POST",
            body=params,
            callback=self.async_callback(self._on_user_auth, callback)
        )
 
    def authorize_redirect(self):
        super(InstagramMixin, self).authorize_redirect(
            redirect_uri=self.request.full_url(),
            client_id=self._instagram_client_id,
            client_secret=self._instagram_client_secret,
            extra_params={
                "response_type": "code"
            }
        )
 
    def instagram_request(self, path, callback, access_token=None,
                          post_args=None, **args):
        url = self._INSTAGRAM_BASE_URL + path
        all_args = {}
        if access_token:
            all_args["access_token"] = access_token
            all_args.update(args)
 
        if all_args:
            url += "?" + urlencode(all_args)
        callback = self.async_callback(self._on_instagram_request, callback)
        http = self.get_auth_http_client()
        if post_args is not None:
            http.fetch(url, method="POST", body=urlencode(post_args),
                       callback=callback)
        else:
            http.fetch(url, callback=callback)
 
    def _on_instagram_request(self, callback, response):
        if response.error:
            logging.warning("Error response %s fetching %s", response.error,
                            response.request.url)
            callback(None)
            return
        callback(tornado.escape.json_decode(response.body))
 
    def _on_user_auth(self, callback, response):
        data = tornado.escape.json_decode(response.body)
        if "user" in data:
            callback(data)
        else:
            callback(None)
 
    def get_auth_http_client(self):
        return tornado.httpclient.AsyncHTTPClient()
 
    @property
    def _instagram_client_id(self):
        self.require_setting("instagram_client_id")
        return self.settings["instagram_client_id"]
 
    @property
    def _instagram_client_secret(self):
        self.require_setting("instagram_client_secret")
        return self.settings["instagram_client_secret"]
 
 
def strip_qs_params(url, params=[]):
    url = urlparse(url)
    query = parse_qs(url.query)
    for param in params:
        query.pop(param, None)
    return urlunparse(url._replace(query=urlencode(query, True)))