<template lang="pug">
.flexcontainer.flexwrap#table
  .table-row
    .cell.flexspace-and-center Name
      input(
        placeholder='Search',
        class='form-control',
        style='margin: 0 8px;',
        :value='searchQuery'
        @keyup='onSearchQueryChange'
      )
      a(href='#' @click='onAlphabeticalSortClick')
        SortIcon#sort-icon.pull-right(:fill='sortIconColor("alphabetical")')
    .cell.type Type
      a(href='#' @click='onTypeSortClick')
        SortIcon#sort-icon.pull-right(:fill='sortIconColor("type")')
    .cell Nullable
    .cell Representations
    .cell
      .btn(
        v-if='shouldShowExpandAll'
        @click='onClickExpandAll'
      ) Expand All
      .btn(
        v-else
        @click='onClickHideAll'
      ) Hide All
  ps-attribute(
    v-for='a in attributes'
    :attribute='a'
    :manage-mode='manageMode'
    :active-representation='activeRepresentation'
  )
  .no-attributes(v-if='attributes.length === 0').
    There is no attributes in this resource, you can add some
    #[a(:href='editAttributesPath') here]
</template>

<script>
import Vue from 'vue/dist/vue.esm'

import SortIcon from 'images/sort.svg';
import Store from './store.js';
import AttributeComponent from './ps-attribute.vue';

export default {
  props: ['attributes', 'manageMode', 'activeRepresentation', 'sortMode', 'searchQuery'],
  methods: {
    onClickExpandAll: function() {
      $('.contraints-row').collapse('show');
      this.shouldShowExpandAll = false;
    },
    onClickHideAll: function() {
      $('.contraints-row').collapse('hide');
      this.shouldShowExpandAll = true;
    },
    onAlphabeticalSortClick: function() {
      Store.alphabeticalSort();
    },
    onTypeSortClick: function() {
      Store.typeSort();
    },
    onSearchQueryChange: function(e) {
      let text = e.target.value;
      Store.setSearchQuery(text);
    },
    sortIconColor: function(sortType) {
      if (sortType === this.sortMode) {
        return "#008afd";
      } else {
        return "#999999";
      }
    }
  },
  watch: {
    activeRepresentation: function(val, oldVal) {
      if(this.manageMode) {
        Vue.nextTick(this.onClickExpandAll);
      }
    }
  },
  data: function() {
    return {
      shouldShowExpandAll: true
    }
  },
  computed: {
    editAttributesPath: function() {
      return Store.getResourceAttributesEditPath();
    }
  },
  components: {
    SortIcon,
    'ps-attribute': AttributeComponent
  }
}
</script>

<style scoped>
</style>
