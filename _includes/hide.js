let x = localStorage.getItem('hiddenTopics');
let hiddenTopics = x ? JSON.parse(x) : [];
// Create  a new style element that hides all 
// elements with the data-topic=$topic attribute
innerStyle = "";
for (let topic of hiddenTopics) {
  innerStyle += `.topic-${topic} {display:none} `;
}
document.head.insertAdjacentHTML("beforeend", `<style id="hidden-style">${innerStyle}</style>`)