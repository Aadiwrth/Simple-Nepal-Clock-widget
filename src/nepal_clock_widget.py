import tkinter as tk
from tkinter import ttk, Menu
import json
import os
from datetime import datetime
import pytz
import sys

class NepalClockWidget:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Nepal Clock")
        
        # Remove title bar and make it always on top
        self.root.overrideredirect(True)
        self.root.attributes('-topmost', True)
        
        # Handle transparency on Windows/Linux
        try:
            self.root.attributes('-alpha', 0.95)  # Slight transparency
        except:
            pass
        
        # Modern dark theme colors
        self.colors = {
            'bg': '#1a1a1a',
            'secondary_bg': '#2d2d2d',
            'primary': '#00d4aa',
            'secondary': '#888888',
            'text': '#ffffff',
            'accent': '#4CAF50'
        }
        
        self.root.configure(bg=self.colors['bg'])
        
        # Settings file for position and size
        self.settings_file = 'nepal_clock_settings.json'
        
        # Nepal timezone
        self.nepal_tz = pytz.timezone('Asia/Kathmandu')
        
        # Dragging variables
        self.start_x = 0
        self.start_y = 0
        self.is_dragging = False
        
        # Load saved settings
        self.load_settings()
        
        # Setup UI
        self.setup_ui()
        
        # Setup right-click context menu
        self.setup_context_menu()
        
        # Start clock update
        self.update_clock()
        
        # Bind events for dragging
        self.setup_dragging()
        
        # Bind events for window management
        self.setup_window_events()
        
        # Save settings on close
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)

    def setup_ui(self):
        # Main container with rounded corners effect
        self.main_frame = tk.Frame(
            self.root, 
            bg=self.colors['bg'], 
            relief='flat', 
            bd=0,
            padx=20,
            pady=15
        )
        self.main_frame.pack(fill='both', expand=True)
        
        # Header with Nepal flag emoji and close button
        self.header_frame = tk.Frame(self.main_frame, bg=self.colors['bg'])
        self.header_frame.pack(fill='x', pady=(0, 10))
        
        # Nepal identifier
        self.nepal_label = tk.Label(
            self.header_frame,
            text="🇳🇵 Kathmandu",
            font=('Segoe UI', 10, 'bold'),
            fg=self.colors['secondary'],
            bg=self.colors['bg']
        )
        self.nepal_label.pack(side='left')
        
        # Close button
        self.close_btn = tk.Label(
            self.header_frame,
            text="✕",
            font=('Segoe UI', 12, 'bold'),
            fg=self.colors['secondary'],
            bg=self.colors['bg'],
            cursor='hand2'
        )
        self.close_btn.pack(side='right')
        self.close_btn.bind('<Button-1>', lambda e: self.on_closing())
        self.close_btn.bind('<Enter>', lambda e: self.close_btn.config(fg='#ff4444'))
        self.close_btn.bind('<Leave>', lambda e: self.close_btn.config(fg=self.colors['secondary']))
        
        # Time display with larger, modern font
        self.time_label = tk.Label(
            self.main_frame,
            text="00:00:00",
            font=('SF Pro Display', 32, 'bold') if sys.platform == 'darwin' else ('Segoe UI', 32, 'bold'),
            fg=self.colors['primary'],
            bg=self.colors['bg']
        )
        self.time_label.pack(pady=(5, 5))
        
        # AM/PM indicator
        self.ampm_label = tk.Label(
            self.main_frame,
            text="AM",
            font=('Segoe UI', 14, 'normal'),
            fg=self.colors['secondary'],
            bg=self.colors['bg']
        )
        self.ampm_label.pack()
        
        # Date display with elegant styling
        self.date_label = tk.Label(
            self.main_frame,
            text="January 1, 2025",
            font=('Segoe UI', 13, 'normal'),
            fg=self.colors['text'],
            bg=self.colors['bg']
        )
        self.date_label.pack(pady=(8, 5))
        
        # Timezone indicator
        self.timezone_label = tk.Label(
            self.main_frame,
            text="GMT +5:45",
            font=('Segoe UI', 9),
            fg=self.colors['secondary'],
            bg=self.colors['bg']
        )
        self.timezone_label.pack(pady=(0, 5))
        
        # Status dot for live indicator
        self.status_frame = tk.Frame(self.main_frame, bg=self.colors['bg'])
        self.status_frame.pack(pady=(5, 0))
        
        self.status_dot = tk.Label(
            self.status_frame,
            text="●",
            font=('Segoe UI', 8),
            fg=self.colors['accent'],
            bg=self.colors['bg']
        )
        self.status_dot.pack(side='left')
        
        self.status_text = tk.Label(
            self.status_frame,
            text=" Live",
            font=('Segoe UI', 8),
            fg=self.colors['secondary'],
            bg=self.colors['bg']
        )
        self.status_text.pack(side='left')

    def setup_context_menu(self):
        # Right-click context menu
        self.context_menu = Menu(self.root, tearoff=0, bg=self.colors['secondary_bg'], 
                                fg=self.colors['text'], activebackground=self.colors['accent'])
        self.context_menu.add_command(label="Always on Top ✓", command=self.toggle_topmost)
        self.context_menu.add_separator()
        self.context_menu.add_command(label="Reset Position", command=self.reset_position)
        self.context_menu.add_command(label="Toggle Transparency", command=self.toggle_transparency)
        self.context_menu.add_separator()
        self.context_menu.add_command(label="Exit", command=self.on_closing)
        
        # Bind right-click to show context menu
        self.root.bind('<Button-3>', self.show_context_menu)
        for widget in [self.main_frame, self.time_label, self.date_label, self.nepal_label]:
            widget.bind('<Button-3>', self.show_context_menu)

    def show_context_menu(self, event):
        try:
            self.context_menu.tk_popup(event.x_root, event.y_root)
        finally:
            self.context_menu.grab_release()

    def toggle_topmost(self):
        current = self.root.attributes('-topmost')
        self.root.attributes('-topmost', not current)
        
        # Update menu text
        menu_text = "Always on Top ✓" if not current else "Always on Top"
        self.context_menu.entryconfig(0, label=menu_text)

    def toggle_transparency(self):
        try:
            current_alpha = self.root.attributes('-alpha')
            new_alpha = 1.0 if current_alpha < 1.0 else 0.85
            self.root.attributes('-alpha', new_alpha)
        except:
            pass

    def setup_dragging(self):
        # Bind mouse events for dragging to multiple widgets
        widgets_to_bind = [
            self.root, self.main_frame, self.time_label, 
            self.date_label, self.nepal_label, self.header_frame,
            self.ampm_label, self.timezone_label, self.status_frame
        ]
        
        for widget in widgets_to_bind:
            widget.bind('<Button-1>', self.start_drag)
            widget.bind('<B1-Motion>', self.drag_window)
            widget.bind('<ButtonRelease-1>', self.end_drag)

    def start_drag(self, event):
        self.start_x = event.x_root - self.root.winfo_x()
        self.start_y = event.y_root - self.root.winfo_y()
        self.is_dragging = True
        
        # Visual feedback
        self.root.configure(cursor='fleur')

    def drag_window(self, event):
        if self.is_dragging:
            x = event.x_root - self.start_x
            y = event.y_root - self.start_y
            self.root.geometry(f"+{x}+{y}")

    def end_drag(self, event):
        self.is_dragging = False
        self.root.configure(cursor='')

    def setup_window_events(self):
        # Handle window focus events for better UX
        self.root.bind('<FocusIn>', self.on_focus_in)
        self.root.bind('<FocusOut>', self.on_focus_out)
        
        # Handle escape key to close
        self.root.bind('<Escape>', lambda e: self.on_closing())
        
        # Make window focusable
        self.root.focus_set()

    def on_focus_in(self, event):
        try:
            self.root.attributes('-alpha', 1.0)
        except:
            pass

    def on_focus_out(self, event):
        try:
            self.root.attributes('-alpha', 0.95)
        except:
            pass

    def update_clock(self):
        try:
            # Get current Nepal time
            nepal_time = datetime.now(self.nepal_tz)
            
            # Format time in 12-hour format
            time_str = nepal_time.strftime("%I:%M:%S")
            ampm_str = nepal_time.strftime("%p")
            date_str = nepal_time.strftime("%A, %B %d, %Y")
            
            # Remove leading zero from hour
            if time_str.startswith('0'):
                time_str = time_str[1:]
            
            # Update labels
            self.time_label.config(text=time_str)
            self.ampm_label.config(text=ampm_str)
            self.date_label.config(text=date_str)
            
            # Animate status dot (pulse effect)
            current_color = self.status_dot.cget('fg')
            new_color = self.colors['primary'] if current_color == self.colors['accent'] else self.colors['accent']
            self.status_dot.config(fg=new_color)
            
        except Exception as e:
            print(f"Clock update error: {e}")
        
        # Schedule next update
        self.root.after(1000, self.update_clock)

    def reset_position(self):
        # Reset to top-right corner of screen
        screen_width = self.root.winfo_screenwidth()
        self.root.geometry(f"280x180+{screen_width-300}+50")

    def load_settings(self):
        try:
            if os.path.exists(self.settings_file):
                with open(self.settings_file, 'r') as f:
                    settings = json.load(f)
                    x = settings.get('x', 50)
                    y = settings.get('y', 50)
                    width = settings.get('width', 280)
                    height = settings.get('height', 180)
                    topmost = settings.get('topmost', True)
                    
                    self.root.geometry(f"{width}x{height}+{x}+{y}")
                    self.root.attributes('-topmost', topmost)
                    
                    # Update context menu
                    menu_text = "Always on Top ✓" if topmost else "Always on Top"
                    self.context_menu.entryconfig(0, label=menu_text)
            else:
                # Default position: top-right corner
                screen_width = self.root.winfo_screenwidth()
                self.root.geometry(f"280x180+{screen_width-300}+50")
        except Exception as e:
            print(f"Settings load error: {e}")
            screen_width = self.root.winfo_screenwidth()
            self.root.geometry(f"280x180+{screen_width-300}+50")

    def save_settings(self):
        try:
            # Get current window position and size
            self.root.update_idletasks()
            geometry = self.root.geometry()
            topmost = self.root.attributes('-topmost')
            
            # Parse geometry string (e.g., "280x180+100+200")
            parts = geometry.replace('+', ' +').replace('-', ' -').split()
            size_part = parts[0]
            x_part = int(parts[1]) if len(parts) > 1 else 50
            y_part = int(parts[2]) if len(parts) > 2 else 50
            
            width, height = map(int, size_part.split('x'))
            
            settings = {
                'width': width,
                'height': height,
                'x': x_part,
                'y': y_part,
                'topmost': topmost
            }
            
            with open(self.settings_file, 'w') as f:
                json.dump(settings, f, indent=2)
        except Exception as e:
            print(f"Settings save error: {e}")

    def on_closing(self):
        self.save_settings()
        self.root.quit()
        self.root.destroy()

    def run(self):
        try:
            self.root.mainloop()
        except KeyboardInterrupt:
            self.on_closing()

def install_requirements():
    """Install required packages if not available"""
    required_packages = ['pytz']
    
    for package in required_packages:
        try:
            __import__(package)
        except ImportError:
            print(f"Installing required package: {package}")
            import subprocess
            subprocess.check_call([sys.executable, "-m", "pip", "install", package])

def main():
    # Install requirements
    install_requirements()
    
    # Create and run the clock widget
    try:
        app = NepalClockWidget()
        app.run()
    except Exception as e:
        print(f"Application error: {e}")
        input("Press Enter to exit...")

if __name__ == "__main__":
    main()