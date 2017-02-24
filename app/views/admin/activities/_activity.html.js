<script type="text/template" id="activity">
  <tr data-id="{0}" data-email="{3}">
    <td><a href="/members/{1}">{2}</a></td>
    <td style="padding: 0px; min-width: 60%; width: 25%;">
      <input class="price" type="text" value="{4}">
    </td>
    <td style='min-width: 50%; width: 50%;'>
      <p></p>
    </td>
    <td class="buttons">
      <div class="btn-group">
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