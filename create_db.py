# create_db.py

# We import the 'app' and 'db' objects from our main app.py file
from app import app, db, User, bcrypt

# --- Function to Create Tables ---
def create_tables():
    """Creates all database tables defined in our models."""
    print("Creating database tables...")
    with app.app_context():
        db.create_all()
    print("Tables created successfully.")

# --- Function to Create Admin User ---
def create_admin():
    """Creates the default admin user."""
    print("Creating admin user...")
    with app.app_context():
        # Check if the admin user already exists
        admin = User.query.filter_by(username='admin').first()
        if admin:
            print("Admin user already exists.")
            return

        # Hash the password
        hashed_password = bcrypt.generate_password_hash('password').decode('utf-8')

        # Create the new user object
        new_admin = User(username='admin', password=hashed_password)

        # Add to the database and commit
        db.session.add(new_admin)
        db.session.commit()
        print("Admin user 'admin' with password 'password' created.")

# --- Main Execution ---
if __name__ == '__main__':
    create_tables()
    create_admin()