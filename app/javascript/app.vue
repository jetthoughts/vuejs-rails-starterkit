<template>
  <div id="app">
    <img alt="Logo" src="../assets/images/logo.png" width="350">
    <p>{{ message }}</p>
  </div>
</template>

<script>
export default {
  data: function () {
    return {
      message: "Hello Vue!"
    }
  }
}
</script>

<style scoped>
img {
  display: block;
  margin: 15px   auto;
}
p {
  font-size: 2em;
  text-align: center;
}
</style>
