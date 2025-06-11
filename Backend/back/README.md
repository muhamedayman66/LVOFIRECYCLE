# LvofIRecycle Backend

This is the backend for the Lvo-Recycle application, built with Django and Django REST Framework.

## Prerequisites

Make sure you have the following installed on your system:
- Python 3.8+
- pip (Python package installer)

## Installation

1.  **Clone the repository (if you haven't already):**
    ```bash
    git clone https://github.com/muhamedayman66/LVOFIRECYCLE.git

    cd LVOFIRECYCLE/Backend/back
    ```

2.  **Create and activate a virtual environment:**

    -   **On Windows:**
        ```bash
        python -m venv venv
        .\venv\Scripts\activate
        ```

    -   **On macOS/Linux:**
        ```bash
        python3 -m venv venv
        source venv/bin/activate
        ```

3.  **Install the required packages:**
    It is recommended to create a `requirements.txt` file. For now, you can install the packages directly:
    ```bash
    pip install Django djangorestframework django-cors-headers Pillow
    ```

## Running the Application

1.  **Apply database migrations:**
    This will create the `db.sqlite3` file and set up the database schema.
    ```bash
    python manage.py migrate
    ```

2.  **Run the development server:**
    ```bash
    python manage.py runserver
    ```

    The application will be running at `http://127.0.0.1:8000/`.

## Project Structure

-   `back/`: Contains the main Django project settings.
-   `api/`: The main Django app containing the models, views, and serializers for the API.
-   `manage.py`: Django's command-line utility for administrative tasks.
-   `db.sqlite3`: The SQLite database file.
-   `media/`: Contains user-uploaded files.
