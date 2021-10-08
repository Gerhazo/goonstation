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
    <Window>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={selected_main_tab_index === 1}
            onClick={() => act('set_main_tab_index', { index: 1 })}>
            Tab one
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
          Tab selected: {selected_main_tab_index}
          <Button
            icon="id-card"
            onClick={() => act('insert_card')}
          >
            Insert ID
          </Button>
        </Box>
      </Window.Content>
    </Window>
  );
};
