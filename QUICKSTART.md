# ⚡ Quick Start - Get Running in 5 Minutes!

Follow these steps to get your app running quickly. For detailed explanations, see `SETUP_GUIDE.md`.

## ✅ Prerequisites

- [x] Node.js installed? Run: `node --version`
- [x] Flutter installed? Run: `flutter doctor`
- [x] Emulator ready or phone connected? Run: `flutter devices`

If any of these don't work, see `SETUP_GUIDE.md` for installation instructions.

## 🚀 Let's Go!

### 1. Start the Backend (2 minutes)

Open a terminal and run:

```bash
# Navigate to backend folder
cd backend

# Install packages (first time only)
npm install

# Start the server
npm start
```

✅ You should see: "Server running on http://localhost:3000"

**⚠️ IMPORTANT: Keep this terminal open!**

### 2. Find Your Computer's IP Address (30 seconds)

Open a **new terminal** and run:

**Windows:**
```bash
ipconfig
```
Look for "IPv4 Address" (e.g., `192.168.1.100`)

**Mac/Linux:**
```bash
hostname -I
```

**Write it down!** Example: `192.168.1.100`

### 3. Run the Flutter App (2 minutes)

In the **same new terminal**, run:

```bash
# Navigate to mobile folder
cd mobile

# Get packages (first time only)
flutter pub get

# Run the app
flutter run
```

⏳ First build takes 2-3 minutes - be patient!

✅ App should open on your device/emulator

### 4. Configure & Use the App (1 minute)

**On the first screen (Setup):**

Using Android Emulator on same computer?
```
http://10.0.2.2:3000
```

Using a real phone/device?
```
http://YOUR_IP:3000
```
(Replace YOUR_IP with the address from step 2)

**Example:** `http://192.168.1.100:3000`

Tap **Continue**

**On the Login screen:**
1. Tap **Register**
2. Enter any username (e.g., "john")
3. Enter any password (e.g., "password123")
4. Tap **Register**

**You're in!** 🎉

Tap the **+** button to create your first note!

## 🎯 What Now?

### If Everything Works:
1. Create a few notes
2. Edit and delete them
3. Read `backend/README.md` to understand the backend
4. Read `mobile/README.md` to understand the Flutter app
5. Start experimenting with the code!

### If Something Doesn't Work:
1. Check `SETUP_GUIDE.md` for detailed troubleshooting
2. Make sure:
   - Backend terminal is still running
   - You're using `http://` not `https://`
   - Phone and computer are on same WiFi (if using real device)
   - Firewall isn't blocking port 3000

## 📚 Documentation

- **SETUP_GUIDE.md** - Detailed setup instructions with troubleshooting
- **README.md** - Project overview and learning resources
- **backend/README.md** - Backend API documentation
- **mobile/README.md** - Flutter app documentation

## 💡 Quick Tips

**Hot Reload (Flutter):**
While the app is running, press `r` in the terminal to reload changes without restarting!

**Stop the Backend:**
In the backend terminal, press `Ctrl+C`

**Stop the Flutter App:**
In the Flutter terminal, press `q`

**Restart Everything:**
If things get weird, just restart both the backend and the Flutter app!

## 🐛 Common First-Time Issues

**"No devices found"**
→ Start your emulator or connect your phone

**"Network Error" in app**
→ Check backend is running, verify IP address is correct

**"npm: command not found"**
→ Node.js not installed or terminal needs restart

**"flutter: command not found"**
→ Flutter not installed or terminal needs restart

## 🚀 You're All Set!

You now have a working full-stack app! Time to explore and learn!

**Next steps:**
1. Create some notes and play around
2. Read the code comments - they explain everything
3. Make small changes and see what happens
4. Check out the learning resources in README.md

**Happy coding! 🎉**
