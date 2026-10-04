defmodule LanternDemoWeb.Docs.Patterns do
  @moduledoc false
  use LanternDemoWeb.Docs.Section

  def member(%{member: "chat-kit"} = assigns) do
    ~H"""
    <p>
      A composed conversation demo using avatars, message rows, and an accessible
      follow-aware message scroller. The controls make the scroll and busy states
      visible without background work.
    </p>
    <.demo_section
      title="Conversation"
      description="A fixed-height transcript keeps MessageScroller as the inner scroll region; append, stream, and reset are ordinary LiveView events."
      code={~S'''
      <.message_scroller id="chat-kit-demo" label="Chat kit conversation" follow={true} busy={@chat_demo_busy}>
        <.message_scroller_item
          :for={{message, index} <- Enum.with_index(@chat_demo_messages)}
          message_id={message.id}
          scroll_anchor={index == length(@chat_demo_messages) - 1 and not @chat_demo_busy}
        >
          <.message align={message.align} tone={message.tone}>
            <:avatar><.avatar initials={message.initials} /></:avatar>
            <:header>{message.header}</:header>
            {message.body}
            <:footer>{message.footer}</:footer>
          </.message>
        </.message_scroller_item>
        <.message_scroller_item :if={@chat_demo_busy} message_id="chat-streaming" scroll_anchor>
          <.message align="start" tone="surface">
            <:avatar><.avatar initials="LU" /></:avatar>
            <:header>Assistant - now</:header>
            Assistant is typing...
          </.message>
        </.message_scroller_item>
      </.message_scroller>
      '''}
    >
      <div class="docs-row docs-chat-controls">
        <Button.button size="sm" phx-click="chat_append_reply">Append reply</Button.button>
        <Button.button size="sm" variant="outline" phx-click="chat_toggle_streaming">
          Toggle streaming
        </Button.button>
        <Button.button size="sm" variant="ghost" phx-click="chat_reset">Reset</Button.button>
      </div>
      <div class="docs-chat-frame">
        <MessageScroller.message_scroller
          id="chat-kit-demo"
          label="Chat kit conversation"
          follow={true}
          busy={@chat_demo_busy}
        >
          <MessageScroller.message_scroller_item
            :for={{message, index} <- Enum.with_index(@chat_demo_messages)}
            id={message.id}
            message_id={message.id}
            scroll_anchor={index == length(@chat_demo_messages) - 1 and not @chat_demo_busy}
          >
            <Message.message align={message.align} tone={message.tone}>
              <:avatar><Avatar.avatar initials={message.initials} /></:avatar>
              <:header>{message.header}</:header>
              <p :for={paragraph <- String.split(message.body, "\n\n")}>{paragraph}</p>
              <:footer>{message.footer}</:footer>
            </Message.message>
          </MessageScroller.message_scroller_item>
          <MessageScroller.message_scroller_item
            :if={@chat_demo_busy}
            id="chat-streaming"
            message_id="chat-streaming"
            scroll_anchor
          >
            <Message.message align="start" tone="surface">
              <:avatar><Avatar.avatar initials="LU" /></:avatar>
              <:header>Assistant - now</:header>
              <span class="docs-chat-typing">Assistant is typing...</span>
            </Message.message>
          </MessageScroller.message_scroller_item>
        </MessageScroller.message_scroller>
      </div>
    </.demo_section>
    """
  end
end
