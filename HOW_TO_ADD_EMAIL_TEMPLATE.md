# How to Add Custom Email Verification Template to Firebase

## Step-by-Step Guide

### **Step 1: Open Firebase Console**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your **fitness-app-18217** project
3. Click on **Authentication** in the left sidebar

### **Step 2: Go to Email Templates**
1. Click on **Templates** (or "Email Templates" depending on your version)
2. Select **Email address verification** from the list
3. You should see the current template

### **Step 3: Edit the Template**
1. Click the **Edit** button (pencil icon) or **Edit email template** button
2. A popup or new page will open with template editing options

### **Step 4: Customize the Sender Name**
In the popup, you'll see fields like:
- **Sender name**: Change from "not provided" to **"Fitness Tracker"**
- **From**: Keep as `noreply@fitness-app-18217.firebaseapp.com`
- **Reply to**: Keep as `noreply`

### **Step 5: Customize the Subject**
Change the **Subject** field to:
```
Verify Your Fitness Tracker Account
```

### **Step 6: Replace the Message with Custom HTML**
1. Look for the **Message** section
2. You'll see a text editor - scroll down to find an option like "HTML" or toggle to switch from plain text to HTML
3. **Clear all existing content**
4. **Copy the entire HTML code** from the file we created
5. **Paste it** into the message field

### **Step 7: Important - Replace Firebase Placeholders**
Look for these Firebase variables in the template and keep them:
- **`%LINK%`** - The verification link (already in our template)
- **`%DISPLAY_NAME%`** - User's display name (if needed, can add to greeting)
- **`%APP_NAME%`** - Your app name

Our template uses `%LINK%` which Firebase will automatically replace with the actual verification URL.

### **Step 8: Save the Template**
1. Click **Save** or **Update** button at the bottom
2. Firebase will show a confirmation message

### **Step 9: Test the Template**
1. Go back to the Authentication Users page
2. Create a test account or use an existing one
3. Send a test verification email to see how it looks
4. Check your inbox and spam folder

---

## What Each Firebase Variable Does

| Variable | What it becomes |
|----------|-----------------|
| `%LINK%` | The actual verification URL link |
| `%DISPLAY_NAME%` | User's name (if set) |
| `%APP_NAME%` | Your Firebase project name |

---

## If You Get an Error

### **Error: "HTML not supported" or "Invalid template"**
- Make sure you're using the **entire HTML code** including `<!DOCTYPE html>` and closing tags
- Check that all `<` and `>` symbols are present
- Avoid copying partial code

### **Error: "Content too large"**
- The template is too long for Firebase
- This shouldn't happen with our template as it's optimized

### **Template not updating**
- Clear your browser cache (Ctrl+Shift+Delete or Cmd+Shift+Delete on Mac)
- Try a different browser
- Log out and log back into Firebase Console

---

## Testing Your Email

After saving, send yourself a test email:

1. **Create a new test account** in your app or Firebase Console
2. **Check your inbox** for the verification email
3. **Check spam folder** if not in inbox
4. **Click the verification link** to test it works
5. **Go back to the app** and tap "I've Verified My Email"

---

## Quick HTML Copy-Paste

If you have trouble finding the HTML editor:

1. Open the file: `EMAIL_VERIFICATION_TEMPLATE.html`
2. Select **all content** (Ctrl+A)
3. Copy it (Ctrl+C)
4. In Firebase, find the **Message** field
5. Clear existing content
6. Paste (Ctrl+V)
7. Save

---

## Firebase Console Navigation

**Path:** Authentication → Templates → Email address verification → Edit

Or:

**Path:** [Firebase Console](https://console.firebase.google.com) 
→ Your Project 
→ Authentication 
→ Templates 
→ Email address verification 
→ Edit Template

---

## Preview Before Saving

Most email template editors have a **Preview** button. Use it to see how your email looks on:
- Desktop
- Mobile
- Different email clients (Gmail, Outlook, etc.)

---

## Need Help?

If you still can't find where to add the template:

1. **Make sure you're logged in** to Firebase Console
2. **Select the correct project** (fitness-app-18217)
3. **Click Authentication** - it's blue in the left sidebar
4. Look for **Templates** or **Email Templates**
5. Click on **Email address verification**
6. Look for an **Edit** button or **pencil icon**

If you still need help, try:
- [Firebase Email Templates Documentation](https://firebase.google.com/docs/auth/custom-email-handler)
- Contact Firebase Support

---

## Summary

| Step | Action |
|------|--------|
| 1 | Go to Firebase Console → Authentication |
| 2 | Click Templates → Email address verification |
| 3 | Click Edit/Pencil icon |
| 4 | Change Sender name to "Fitness Tracker" |
| 5 | Change Subject to "Verify Your Fitness Tracker Account" |
| 6 | Replace Message with our HTML code |
| 7 | Click Save |
| 8 | Test by sending a verification email |

That's it! Your custom email is now live! 🚀
