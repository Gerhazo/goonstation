import { useBackend, useLocalState } from '../backend';
import { Tabs, Box, BlockQuote, Button, LabeledList, Divider, Icon, NoticeBox, NumberInput, Section, Stack } from '../components';
import { Window } from '../layouts';

export const IdentificationComputer = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    authentication_card,
    modified_card,
    is_authenticated,
    id_computer_process_data,
    selected_main_tab_index,
  } = data;
  return (
    <Window
      width={670}
      height={640}
    >
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={selected_main_tab_index === 1}
            onClick={() => act('set_main_tab_index', { index: 1 })}>
            Authentication
          </Tabs.Tab>
          {!!is_authenticated && (
            <>
              <Tabs.Tab
                selected={selected_main_tab_index === 2}
                onClick={() => act('set_main_tab_index', { index: 2 })}>
                Tab two
              </Tabs.Tab>
              <Tabs.Tab
                selected={selected_main_tab_index === 3}
                onClick={() => act('set_main_tab_index', { index: 3 })}>
                Tab three
              </Tabs.Tab>
            </>
          )}
        </Tabs>
        <Box>
          <Section
            title="Authentication"
          >
            <Stack vertical>
              <Stack.Item>
                <NoticeBox info>
                  You must insert your ID to continue!
                </NoticeBox>
              </Stack.Item>
              <Stack.Item>
                No ID has been detected. The machine&apos;s functionality is locked down.
              </Stack.Item>
              <Stack.Item>
                <strong>Authentication ID: </strong>
                <Button
                  icon="eject"
                  onClick={() => act('insert_authentication_id')}
                >
                  {authentication_card ? ("Eject ID: " + authentication_card) : "Insert ID"}
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
          <Section
            title="Auxillary Inputs"
          >
            <Stack vertical>
              <Stack.Item>
                <strong>Target modification ID: </strong>
                <Button
                  icon="eject"
                  onClick={() => act('insert_target_id')}
                >
                  {modified_card ? ("Eject ID: " + modified_card) : "Insert ID"}
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Box>
      </Window.Content>
    </Window>
  );
};

const SlotWindow = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    authentication_card,
  } = data;

  return (
    <>

    </>
  );
};
