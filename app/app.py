# app.py

import os
from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(__file__), '..', '.env')) # Load the .env file

from flask import Flask, render_template, request, redirect, url_for, flash, abort
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_login import LoginManager, UserMixin, login_user, current_user, logout_user, login_required
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, TextAreaField
from wtforms.validators import DataRequired

# --- App & Config Setup ---

# Get the absolute path to the project root
project_root = os.path.abspath(os.path.dirname(__file__))  # /app/app

app = Flask(__name__,
            template_folder=os.path.join(project_root, 'templates'),
            static_folder=os.path.join(project_root, '..', 'client', 'static'))


app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY')
# --- THIS IS THE FIX ---
# Point to the correct database path (sqlite for local, postgres for prod)
local_db_path = os.path.join(project_root, 'blog.db')
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL', f'sqlite:///{local_db_path}')

# --- Database & Auth Setup ---

db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'
login_manager.login_message_category = 'danger' # Use our 'danger' (red) category

# --- Database Models (Our Tables) ---

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# UserMixin adds the required fields for Flask-Login (like is_authenticated)
class User(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)

    def __repr__(self):
        return f"User('{self.username}')"

class Post(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    content = db.Column(db.Text, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    author = db.relationship('User', backref=db.backref('posts', lazy=True))

    def __repr__(self):
        return f"Post('{self.title}')"

# --- Forms (for Login) ---

class LoginForm(FlaskForm):
    """Our login form class."""
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Login')

class PostForm(FlaskForm):
    """Our form class for creating/editing posts."""
    title = StringField('Title', validators=[DataRequired()])
    content = TextAreaField('Content', validators=[DataRequired()])
    submit = SubmitField('Save Post')
# --- Routes (Webpages) ---

@app.route('/')
def index():
    """Main homepage: Shows all posts."""
    posts = Post.query.order_by(Post.id.desc()).all()
    return render_template('index.html', posts=posts)

@app.route('/login', methods=['GET', 'POST'])
def login():
    """Handles the user login page."""
    if current_user.is_authenticated:
        return redirect(url_for('admin')) # If already logged in, go to admin
    
    form = LoginForm()
    if form.validate_on_submit():
        # Find the user in the database
        user = User.query.filter_by(username=form.username.data).first()
        
        # Check if user exists and the password is correct
        if user and bcrypt.check_password_hash(user.password, form.password.data):
            login_user(user) # Log them in
            flash('Login successful!', 'success')
            return redirect(url_for('admin'))
        else:
            flash('Login failed. Check username and password.', 'danger')
            
    return render_template('login.html', form=form)

@app.route('/logout')
def logout():
    """Logs the user out."""
    logout_user()
    flash('You have been logged out.', 'success')
    return redirect(url_for('index'))

@app.route('/admin')
@login_required # This is the magic! Protects this page.
def admin():
    """Admin dashboard page."""
    posts = Post.query.order_by(Post.id.desc()).all()
    return render_template('admin.html', posts=posts)

@app.route('/post/new', methods=['GET', 'POST'])
@login_required
def create():
    """Handles the 'Create New Post' page."""
    form = PostForm()
    if form.validate_on_submit():
        # Create a new post object, linking it to the logged-in user
        post = Post(title=form.title.data, 
                    content=form.content.data, 
                    author=current_user)
        db.session.add(post)
        db.session.commit()
        flash('Your post has been created!', 'success')
        return redirect(url_for('admin'))

    return render_template('create_edit_post.html', title='New Post', form=form)

@app.route('/post/<int:post_id>/edit', methods=['GET', 'POST'])
@login_required
def edit(post_id):
    """Handles editing an existing post."""
    post = Post.query.get_or_404(post_id)

    # Security check: only the author can edit their post
    if post.author != current_user:
        abort(403) # Forbidden

    form = PostForm()
    if form.validate_on_submit():
        # Update the post's data
        post.title = form.title.data
        post.content = form.content.data
        db.session.commit()
        flash('Your post has been updated!', 'success')
        return redirect(url_for('admin'))
    elif request.method == 'GET':
        # Pre-fill the form with the existing post data
        form.title.data = post.title
        form.content.data = post.content

    return render_template('create_edit_post.html', title='Edit Post', form=form)

@app.route('/post/<int:post_id>/delete', methods=['POST'])
@login_required
def delete(post_id):
    """Handles deleting a post."""
    post = Post.query.get_or_404(post_id)
    if post.author != current_user:
        abort(403)

    db.session.delete(post)
    db.session.commit()
    flash('Your post has been deleted.', 'success')
    return redirect(url_for('admin'))

# We will add create/edit/delete routes here in the next step

# --- Run the App ---

if __name__ == '__main__':
    # We don't need the init_db() check anymore,
    # we have our 'create_db.py' script for that.
    app.run(debug=True, host='0.0.0.0', port=5000)