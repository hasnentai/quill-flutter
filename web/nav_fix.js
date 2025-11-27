// Prevent browser default horizontal swipes which interfere with navigating
// the app.
document.body.style.overscrollBehavior = "none";
document.documentElement.style.overscrollBehavior = "none";

// Apply CSS that might help with some browsers
const style = document.createElement("style");
style.textContent = `
  * {
    overscroll-behavior: none !important;
    -webkit-overflow-scrolling: auto !important;
  }
  
  body, html {
    touch-action: pan-y !important;
  }
`;
document.head.appendChild(style);