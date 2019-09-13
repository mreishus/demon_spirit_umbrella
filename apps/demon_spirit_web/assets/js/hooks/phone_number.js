let PhoneNumber = {
  mounted() {
    console.log("mounted running");
    this.el.addEventListener("input", e => {
      console.log("match running");
      let match = this.el.value
        .replace(/\D/g, "")
        .match(/^(\d{3})(\d{3})(\d{4})$/);
      if (match) {
        console.log("trying to set");
        this.el.value = `${match[1]}-${match[2]}-${match[3]}`;
      }
    });
  }
};
export default PhoneNumber;

