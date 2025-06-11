import os
import django
import sys

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'back.settings')
django.setup()

from api.models import Register

def reset_user_password(email, new_password):
    """
    Resets the password for a given user to a new plain-text password.
    """
    try:
        user = Register.objects.get(email=email)
        user.password = new_password
        user.save()
        print(f"Successfully reset password for {email}")
    except Register.DoesNotExist:
        print(f"User with email {email} not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == '__main__':
    # IMPORTANT: This script is for temporary debugging.
    # Replace with the actual email and desired new password.
    email_to_reset = "muhamed2101320@gmail.com"
    password_to_set = "password123"
    reset_user_password(email_to_reset, password_to_set)