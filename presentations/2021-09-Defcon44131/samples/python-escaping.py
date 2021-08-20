from flask import escape

# ...
def route(user_input):
    # Secure from XSS
    user_input = escape(user_input)
    # ...
    render_data = makeReadable(user_input)
