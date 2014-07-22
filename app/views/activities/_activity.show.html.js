<script type="text/template" id="activity">
  <tr data-id="{0}">
    <td class="col-md-8"><a href="/members/{1}">{2}</a></td>
    <td class="col-md-2">
      <input class="price" style="heigth: 30px; margin: 5px 0; margin-left: 8px; padding: 1px;" type="text" value="{3}">
    </td>
    <td class="col-md-2">
      <div class="btn-group" style="margin-top: 3px; margin-right:3px; float: right;">
        <button class="btn btn-warning paid">
          <i class="fa fa-fw fa-times"></i>
        </button>
        <button class="btn btn-default destroy">
          <i class="fa fa-fw fa-trash-o"></i>
        </button>
      </div>
    </td>
  </tr>
</script>