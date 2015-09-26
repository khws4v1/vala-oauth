using GLib;
using Gtk;
using Rest;

public class Main : Object 
{
    const string UI_FILE = "/ui/oauth-vala.ui";
    const string REST_URL = "https://api.twitter.com/";
    const string REQUEST_TOKEN_FUNC_NAME = "oauth/request_token";
    const string AUTHORIZE_FUNC_NAME = "oauth/authorize";
    const string ACCESS_TOKEN_FUNC_NAME = "oauth/access_token";

    OAuthProxy proxy;
    string consumer_key;
    string consumer_secret;
    string request_token;
    string request_token_secret;
    Entry consumer_key_entry;
    Entry consumer_secret_entry;
    Entry pin_code_entry;
    Entry access_token_entry;
    Entry access_token_secret_entry;

    public Main ()
    {

	    try {
		    var builder = new Builder ();
		    builder.add_from_resource (UI_FILE);
		    builder.connect_signals (this);

		    var window = builder.get_object ("main_window") as Window;
		    window.show_all ();

		    consumer_key_entry = builder.get_object ("consumer_key_entry") as Entry;
		    consumer_secret_entry = builder.get_object ("consumer_secret_entry") as Entry;
		    pin_code_entry = builder.get_object ("pin_code_entry") as Entry;
		    access_token_entry = builder.get_object ("access_token_entry") as Entry;
		    access_token_secret_entry = builder.get_object ("access_token_secret_entry") as Entry;
	    } catch (Error e) {
		    stderr.printf ("Could not load UI: %s\n", e.message);
	    } 

    }

    [CCode (cname = "G_MODULE_EXPORT on_destroy")]
    public void on_destroy (Widget window) 
    {
	    Gtk.main_quit();
    }

    [CCode (cname = "G_MODULE_EXPORT on_start_auth_button_clicked")]
    public void on_start_auth_button_clicked (Button button)
    {
	    access_token_entry.text = "";
	    access_token_secret_entry.text = "";
	    consumer_key = consumer_key_entry.text;
	    consumer_secret = consumer_secret_entry.text;
	    proxy = new OAuthProxy(consumer_key,
	                           consumer_secret,
	                           REST_URL,
	                           false);
	    try {
		    proxy.request_token(REQUEST_TOKEN_FUNC_NAME, "oob");
		    Posix.system ("xdg-open %s".printf(REST_URL + AUTHORIZE_FUNC_NAME
		                                 + "?oauth_token=" + proxy.get_token ()));
	    } catch (Error e) {
		    stderr.printf("%s\n", e.message);
	    }
    }

    [CCode (cname = "G_MODULE_EXPORT on_enter_pin_code_button_clicked")]
    public void on_enter_pin_code_button_clicked(Button button)
    {
	    try {
		    proxy.access_token (ACCESS_TOKEN_FUNC_NAME, pin_code_entry.text);
		    access_token_entry.text = proxy.get_token ();
		    access_token_secret_entry.text = proxy.get_token_secret ();
	    } catch (Error e) {
		    stderr.printf("%s\n", e.message);
	    }
    }

    static int main (string[] args) 
    {
	    Gtk.init (ref args);
	    var app = new Main ();

	    Gtk.main ();
	
	    return 0;
    }
}

