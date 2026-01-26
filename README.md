# 📸 Snapsieve

**Snapsieve** is a simple and intuitive iOS app built with **Swift** and **Xcode** that helps users **compare two or more images side by side** — perfect for deciding between similar photos, outfits, products, or designs.

- Screenshots preview

  <img width="1334" height="326" alt="Snapsieve" src="https://github.com/user-attachments/assets/400d4e8b-1dea-4186-9cf6-f34592ca3bfd" />

---

## ✨ Features

- 📷 **Side-by-side image comparison** — Add and view multiple images at once.  
- 🔍 **Zoom & swipe controls** — Closely inspect photos with smooth gestures, with simple right-swipe like and left-swipe dislike interactions. 
- 🗳️ **Visual decision-making** — Helps users choose their favorites quickly and confidently through lightweight voting. 
- 💾 **Lightweight and fast** — Uses image downsampling and efficient loading to stay responsive even with many photos. 

---

## 🧠 Problem Discovery

Many of us overthink simple visual choices – which selfie to post, which outfit actually looks good, or which product shot will convert better – and we usually end up scrolling back and forth between the same images way too many times. Default gallery apps are great for viewing photos, but they are pretty bad at helping you decide between similar ones; you keep opening and closing images and trying to remember tiny differences in your head.
When I chatted with friends and looked at my own behavior, two patterns kept popping up:
	•	Comparing similar photos is a pain because you’re constantly jumping between them and mentally A/B testing.
	•	Asking for opinions turns into a messy group chat with a bunch of images and zero structured way to see what people actually prefer.
Snapsieve is my attempt to turn all of that into a clean, lightweight flow where you can drop in your options, swipe, tap, and quickly see what “wins” without overthinking it. 

---

## 🧩 Solution Design

The interface is structured as a simple decision flow inspired by social apps, centered on **snaps**, **reactions**, and **ratings**.

- **Onboarding & value proposition**  
  A clean welcome screen introduces Snapsieve and sets the expectation that the app will “make the right decision easier,” with a short, swipeable intro sequence.

- **Snap comparison feed**  
  Users scroll through a vertically stacked feed of images or image pairs, double‑tap to vote for snaps they like, and swipe through alternatives, keeping all comparisons in one focused context. 

- **SnapReactions & emotion capture**  
  An action bar beneath the images exposes quick emoji‑style reactions so users can express how they feel about a snap beyond binary like/dislike, enriching the dataset for decision‑making. 

- **Profile ratings and SnapSieve Score**  
  Each profile or image set aggregates community feedback into a star‑based SnapSieve Rating, shown in a dedicated screen with a grid of contributed snaps for quick overview. 

- **Status, privacy, and reporting**  
  A “no screenshot” overlay clearly communicates privacy expectations when sensitive content is visible, and a contextual report sheet lets users flag offensive snaps directly from the viewer. 

This flow keeps the core task—picking the best visual option—front and center while still supporting rich, social-style feedback.

---

## 🚧 Challenges Faced

- **Managing complex gesture interactions**  
  Combining double‑tap to like, horizontal swipes for navigation, and potential zoom gestures required careful configuration of gesture recognizers to avoid conflicts and accidental triggers. 

- **Image performance and memory usage**  
  Loading multiple high‑resolution images in comparison views risked jank and memory pressure, so the app uses downsampling and efficient formats to keep scrolling smooth.

- **Balancing minimal UI with rich feedback**  
  The design needed to expose reactions, ratings, and reporting without cluttering the viewing experience, leading to multiple iterations on layout, spacing, and iconography. 

- **Communicating privacy without hard technical locks**  
  Because screenshots cannot be fully blocked by apps on iOS, the solution relied on clear visual cues (overlay states and copy) to set expectations around screenshots and content use.  

- **Algorithm Performance Issues**  
  Because of the vast number of images and filtering that needs to be done to show the right images to the right users, we had a challenge in building out the algorithm to make the experience seamless.
---

## 🛠️ Tech Stack

| Technology | Purpose |
|-----------|---------|
| **Swift** | Core development language |
| **Xcode** | iOS app development environment |
| **UIKit** | UI components and layout |
| **Auto Layout** | Responsive design for multiple screen sizes |

---

## 🖼️ Screenshots


- Onboarding / intro screen
  
  <img width="326" height="1334" alt="Snapsieve" src="https://github.com/user-attachments/assets/92c0f0bd-2393-484b-b93a-6efd0f1d28ce" />

- Snap comparison feed (double‑tap to like)
  
  <img width="326" height="1334" alt="Snapsieve" src="https://github.com/user-attachments/assets/a4a46a94-e47f-4ac4-af27-ce24cd787954" />

- SnapReactions and action bar
  
  <img width="326" height="1334" alt="Snapsieve" src="https://github.com/user-attachments/assets/34761800-06f5-445e-8562-2b6f7d111589" />

- Profile with SnapSieve Rating and snap grid
  
  <img width="326" height="1334" alt="Snapsieve" src="https://github.com/user-attachments/assets/d467eeb9-ae7e-49a0-a3f3-c05491dbbef8" />

- Report / offensive content flow
  
  <img width="326" height="1334" alt="Snapsieve" src="https://github.com/user-attachments/assets/417d9c5d-c2c1-4dfc-94e6-3bff802c4d9f" />



